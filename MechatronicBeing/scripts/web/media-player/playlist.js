/* global MediaPlayer */

document.addEventListener('DOMContentLoaded', function () {
	// if the MediaPlayer class is available
	if ('function' === typeof MediaPlayer) {
		// for each media element
		[].forEach.call(document.querySelectorAll('audio[controls], video[controls]'), function (media) {
			// create an media player from the media element
			var player = media.player = new MediaPlayer(media, jsonParse(media.getAttribute('data-options')));

			// log the media player
			console.log(player);
		});
	}
  
	// the media element
	var media = document.querySelector('audio, video');

	// get the playlist links and prepare them for interaction
	var links = [].slice.call(document.querySelectorAll('.play-list a'));

	// for each playlist link
	links.forEach(function (link) {
		// when the playlist link is clicked
		link.addEventListener('click', function (event) {
			event.preventDefault();

			// update the media src
			media.src = link.href;

			// update link classes
			links.forEach(function (testLink) {
				if (testLink === link) {
					testLink.classList.add('active');
				} else {
					testLink.classList.remove('active');
				}
			});
      
      //Activate media
      media.play();
		});
	});

	// activate the first link
	links[0].click();

	// automatically advance playlist
	media.addEventListener('ended', function () {
		var currentLink = links.filter(function (link) {
			return link.classList.contains('active');
		})[0];

		// current index
		var currentIndex = links.indexOf(currentLink);

		// next index
		var nextIndex = 1 + currentIndex;

		nextIndex = nextIndex === links.length ? 0 : nextIndex;

		// activate the next link
		links[nextIndex].click();
	});
});

function jsonParse(json) {
	try {
		return JSON.parse(json);
	} catch (error) {
		// do nothing and continue
	}

	return null;
}
