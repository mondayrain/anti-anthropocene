"use strict";

const PLAYER_HEIGHT = '390';
const PLAYER_WIDTH = '640';

let videoPlayer;

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
    events: {
      'onReady': onPlayerReady,
    }
  })
};

function onPlayerReady(event) {
  // TODO: Update video title
};

function getRandomVideo() {
  let videoToPlay = VIDEOS[Math.floor(Math.random() * VIDEOS.length)];
  return videoToPlay;
};
