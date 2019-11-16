local repo = 'angelnu/iobroker';
local base_img = 'node:10-stretch';
local no_cache = false;

local Build_Docker_Step(arch, prefix) = {
  name: prefix + 'docker',
  image: 'plugins/docker',
  settings: {
    repo: repo,
    tags: [
      prefix + "${DRONE_BRANCH}-${DRONE_BUILD_NUMBER}-${DRONE_COMMIT}-"+arch,
      prefix + "${DRONE_BRANCH}-"+arch,
      prefix + "latest-"+arch,
    ],
    cache_from: if no_cache then [] else [
      #docker cache
      repo + ":" + prefix + "master-"+arch,
      repo + ":" + prefix + "${DRONE_BRANCH}-"+arch,

      #previous build step
      repo + ":" + "${DRONE_BRANCH}-"+arch,

      #Base repo
      base_img
    ],
    target: prefix + "iobroker",
    username: {
      from_secret: 'DOCKER_USER'
    },
    password: {
      from_secret: 'DOCKER_PASS'
    },
    build_args: [
      'BASE='+base_img,
      'arch='+arch,
      'base_repo='+repo + ":" + "${DRONE_BRANCH}-"+arch,
    ],
  }
};

local Build_Pipeline(prefix, arch) = {
  kind: 'pipeline',
  name: 'build_'+prefix+arch,
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
    Build_Docker_Step(arch, prefix),
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

local Manifest_Pipeline(prefix) = {
  "kind": "pipeline",
  "name": "build_"+prefix+"manifest",
  depends_on: [
    "build_"+prefix+"amd64",
    "build_"+prefix+"arm",
    "build_"+prefix+"arm64",
  ],
  "steps": [
    Manifest_Step(prefix, "${DRONE_BRANCH}-${DRONE_BUILD_NUMBER}-${DRONE_COMMIT}"),
    Manifest_Step(prefix, "${DRONE_BRANCH}"),
    Manifest_Step(prefix, "latest")
  ]
};



[
  Build_Pipeline("","amd64"),
  Build_Pipeline("","arm"),
  Build_Pipeline("","arm64"),
  Manifest_Pipeline(""),

  Build_Pipeline("full-","amd64"),
  Build_Pipeline("full-","arm"),
  Build_Pipeline("full-","arm64"),
  Manifest_Pipeline("full-")
]
