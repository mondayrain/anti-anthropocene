"use strict";

const PLAYER_HEIGHT = getPlayerHeight();
const PLAYER_WIDTH = getPlayerWidth();

let videoPlayer;

// Set the "last updated at" string
let updatedAtElement = document.getElementById('updated-on');
updatedAtElement.innerHTML = LAST_UPDATE;

// Load YouTube's iFrame API asynchronously
let tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
let firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

function onYouTubeIframeAPIReady() {
  videoPlayer = new YT.Player('video-player', {
    height: PLAYER_HEIGHT,
    width: PLAYER_WIDTH,
    videoId: getRandomVideo(),
    events: {},
  })
};

function getRandomVideo() {
  let videoToPlay = VIDEOS[Math.floor(Math.random() * VIDEOS.length)];
  return videoToPlay;
};

function changeVideo() {
  videoPlayer.loadVideoById(getRandomVideo());
};

function getPlayerWidth() {
  return Math.max(getWindowWidth()/2.75, 300);
}

function getPlayerHeight() {
  return Math.max(getWindowHeight()/2.75, 175);
}

function getWindowWidth() {
  return window.innerWidth
    || document.documentElement.clientWidth
    || document.body.clientWidth;
}

function getWindowHeight() {
  return window.innerHeight
    || document.documentElement.clientHeight
    || document.body.clientHeight;
}
