local Build_Docker_Step(arch, prefix) = {
  name: prefix + 'docker',
  image: 'plugins/docker',
  settings: {
    repo: 'angelnu/iobroker',
    tags: [
      prefix + "${DRONE_BRANCH}-${DRONE_BUILD_NUMBER}-${DRONE_COMMIT}-"+arch,
      prefix + "${DRONE_BRANCH}-"+arch,
      prefix + "latest-"+arch,
    ],
    cache_from: [
      #docker cache
      "angelnu/iobroker:" + prefix + "master-"+arch,
      "angelnu/iobroker:" + prefix + "${DRONE_BRANCH}-"+arch,

      #previous build step
      "angelnu/iobroker:" + "${DRONE_BRANCH}-"+arch
    ],
    target: prefix + "iobroker",
    username: {
      from_secret: 'DOCKER_USER'
    },
    password: {
      from_secret: 'DOCKER_PASS'
    },
    build_args: [
      'BASE=node:10-stretch',
      'arch='+arch,
    ],
  }
};

local Build_Pipeline(arch) = {
  kind: 'pipeline',
  name: 'build_'+arch,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
    /* {
      name: 'git_submodules',
      image: 'docker:git',
      commands: [
        'test -e build/build.sh || git submodule update --init --recursive',
      ],
    }, */
    {
      "name": "iobroker_installer_download",
      "image": "plugins/download",
      "settings": {
        "source": "https://github.com/ioBroker/ioBroker/archive/stable-installer.zip",
        "destination": ".build/iobroker-stable.zip"
      }
    },
    {
      "name": "iobroker_installer_checksum",
      "image": "alpine",
      "commands": [
        "md5sum .build/iobroker-stable.zip > .build/iobroker-stable.md5sum",
        "rm .build/iobroker-stable.zip",
      ]
    },
    /* {
      "name": "iobroker_npm_versions",
      "image": "node:current-alpine",
      "commands": [
        "rm -f .build/iobroker.adapters",
        "for pkg in backitup chromecast daikin dwd feiertage flot fritzdect google-sharedlocations harmony history hm-rega hm-rpc; do
          echo \"$$pkg $(npm show iobroker.$pkg version)\">> .build/iobroker.adapters
        done",
      ]
    }, */
    Build_Docker_Step(arch, ""),
    Build_Docker_Step(arch, "full-"),
  ],
};

local Manifest_Step(prefix, tag) = {
  "name": "manifest_" + prefix + tag,
  "image": "plugins/manifest:1",
  "group": "manifest",
  "settings": {
    "username": {
      "from_secret": "DOCKER_USER"
    },
    "password": {
      "from_secret": "DOCKER_PASS"
    },
    "target": "angelnu/iobroker:" + prefix + tag,
    "ignore_missing": true,
    "template": "angelnu/iobroker:" + prefix + "${DRONE_BRANCH}-${DRONE_BUILD_NUMBER}-${DRONE_COMMIT}-ARCH",
    "platforms": [
      "linux/amd64",
      "linux/arm",
      "linux/arm64"
    ]
  }
};

local Manifest_Pipeline() = {
  "kind": "pipeline",
  "name": "build_manifest",
  depends_on: [
    "build_amd64",
    "build_arm",
    "build_arm64",
  ],
  "steps": [
    Manifest_Step("", "${DRONE_BRANCH}-${DRONE_BUILD_NUMBER}-${DRONE_COMMIT}"),
    Manifest_Step("", "${DRONE_BRANCH}"),
    Manifest_Step("", "latest"),
    Manifest_Step("full-", "${DRONE_BRANCH}-${DRONE_BUILD_NUMBER}-${DRONE_COMMIT}"),
    Manifest_Step("full-", "${DRONE_BRANCH}"),
    Manifest_Step("full-", "latest")
  ]
};



[
  Build_Pipeline("amd64"),
  Build_Pipeline("arm"),
  Build_Pipeline("arm64"),
  Manifest_Pipeline()
]
