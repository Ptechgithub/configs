import os
from pytube import YouTube
import platform

def on_progress(stream, chunk, bytes_remaining):
    total_size = stream.filesize
    bytes_downloaded = total_size - bytes_remaining
    percentage = (bytes_downloaded / total_size) * 100
    print(f"Downloading : {percentage:.2f}%", end='\r')

# Clear the terminal based on the OS
if platform.system() == 'Windows':
    os.system('cls')
else:
    os.system('clear')

try:
    # Get the current working directory
    current_dir = os.getcwd()

    # Create the directory if it doesn't exist
    download_dir = os.path.join(current_dir, 'YouTube_dl')
    os.makedirs(download_dir, exist_ok=True)
    
    # Get the video link from the user
    video_url = input("Enter the video link: ")

    # Create a YouTube object using the link
    yt = YouTube(video_url, on_progress_callback=on_progress)

    # Video information
    print("----------------------------------------------------------")
    print(f"Video Title: {yt.title}")
    print(f"Channel Name: {yt.author}")
    print(f"Video Duration: {yt.length // 60} minutes {yt.length % 60} seconds")
    print(f"Views: {yt.views}")
    print(f"Published Date: {yt.publish_date}")
    print("----------------------------------------------------------")
    print(" ")

    # Get all available download formats
    all_formats = yt.streams

    # Filter and sort available formats
    audio_formats = [stream for stream in all_formats if stream.includes_audio_track and stream.resolution is not None]
    sorted_formats = sorted(audio_formats, key=lambda x: (int(x.resolution[:-1]), -x.filesize), reverse=True)

    # Display sorted quality, format, and file size with numbers
    for i, stream in enumerate(sorted_formats):
        print(f"{i + 1}. Quality: {stream.resolution}, F/Rate: {stream.fps} fps, Bitrate: {stream.bitrate / 1000} Kbps, Format: {stream.mime_type}, Audio Codec: {stream.audio_codec}, Filesize: {stream.filesize / 1024 / 1024:.2f} MB")
        print(" -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ")
        
    # Let the user choose a desired format by entering a number
    choice = int(input("Enter the number of quality: ")) - 1

    # Download the video with the selected quality
    selected_format = sorted_formats[choice]
    print(f"Downloading with Quality: {selected_format.resolution} ")
    selected_format.download(output_path=download_dir)
    print(f"Download was successful & Saved to {download_dir}")

except Exception as e:
    print("An error occurred:", str(e))