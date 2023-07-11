echo "Download (and extract) remote resources to your local"
curl -LO https://github.com/MechatronicBeing/resources/archive/refs/heads/main.zip
unzip main.zip
mv resources-main resources
rm main.zip
curl -LO https://github.com/MechatronicBeing/resources-comics/archive/refs/heads/main.zip
unzip main.zip
mv resources-comics-main resources-comics
rm main.zip
curl -LO https://github.com/MechatronicBeing/resources-video-games-music-1/archive/refs/heads/main.zip
unzip main.zip
mv resources-video-games-music-1-main resources-video-games-music-1
rm main.zip
curl -LO https://github.com/MechatronicBeing/resources-video-games-music-2/archive/refs/heads/main.zip
unzip main.zip
mv resources-video-games-music-2-main resources-video-games-music-2
rm main.zip
