import requests

from telegram import (
    ReplyKeyboardMarkup,
    InlineKeyboardMarkup,
    InlineKeyboardButton
)
from telegram.ext import (
    Updater,
    Filters,
    CommandHandler,
    MessageHandler
)


main_keyboard = [
    ['ℹ Help', '💰 Donate']
]


def start(update, context):
    update.message.reply_text(
        '👋 Welcome to my bot! It can download any type of media on Instagram! (Public accounts only)',
        reply_markup=ReplyKeyboardMarkup(main_keyboard, resize_keyboard=True),
    )


def help(update, context):
    update.message.reply_text(
        'Send an Instagram link for a PUBLIC Post, Video, IGTV or Reel to download it! Stories are not currently supported.\n\n'
        'To download a user profile image, just send its username',
        reply_markup=ReplyKeyboardMarkup(main_keyboard, resize_keyboard=True),
    )


def donate(update, context):
    update.message.reply_text(
        'Thank you for donating! ❤\n\nThis will help covering the costs of the hosting',
        reply_markup=InlineKeyboardMarkup(
            [
                [
                    InlineKeyboardButton(
                        'Buy Me A Coffee', 'https://www.buymeacoffee.com/simonfarah'
                    )
                ]
            ]
        ),
    )


def send_post(update, context):
    url = update.message.text

    if '?' in url:
        url += '&__a=1'
    else:
        url += '?__a=1'

    try:
        visit = requests.get(url).json()
        is_video = visit['graphql']['shortcode_media']['is_video']

        try:
            posts = visit["graphql"]["shortcode_media"]["edge_sidecar_to_children"][
                "edges"
            ]

            for post in posts:
                is_video = post["node"]["is_video"]

                if is_video is True:
                    video_url = post["node"]["video_url"]
                    update.message.reply_chat_action("upload_video")
                    update.message.reply_video(video_url)

                elif is_video is False:
                    post_url = post["node"]["display_url"]
                    update.message.reply_chat_action("upload_photo")
                    update.message.reply_photo(post_url)

                else:
                    pass

        except:
            if is_video is True:
                video_url = visit["graphql"]["shortcode_media"]["video_url"]
                update.message.reply_chat_action("upload_video")
                update.message.reply_video(video_url)

            elif is_video is False:
                post_url = visit["graphql"]["shortcode_media"]["display_url"]
                update.message.reply_chat_action("upload_photo")
                update.message.reply_photo(post_url)

            else:
                pass
            
    except:
        update.message.reply_text('Send Me Only Public Instagram Posts')


def send_dp(update, context):
    username = update.message.text
    url = f'https://instagram.com/{username}/?__a=1'

    try:
        visit = requests.get(url).json()
        user_profile = visit['graphql']['user']['profile_pic_url_hd']
        update.message.reply_chat_action('upload_photo')
        update.message.reply_photo(user_profile)
    except:
        update.message.reply_text('Send Me Only Existing Instagram Username')


def main():
    BOT_TOKEN = '5910802300:AAG-XSx4y5eWZbXFEeo6Lr-RFiLScJmUAVE'
    updater = Updater(BOT_TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(CommandHandler('start', start))
    dp.add_handler(MessageHandler(Filters.regex('Help'), help))
    dp.add_handler(MessageHandler(Filters.regex('Donate'), donate))
    dp.add_handler(MessageHandler(Filters.regex('http') & Filters.regex('instagram'), send_post))
    dp.add_handler(MessageHandler(Filters.text, send_dp))

    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    print('Bot is running...')
    main()