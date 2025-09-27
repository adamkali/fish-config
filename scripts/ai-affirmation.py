#!/usr/bin/env python
import requests
import json

OLLAMA_URL = "http://alister:11434/v1/chat/completions"

SYSTEM_PROMPT = """
You are a bot that gives affirmations to the user.
the user's name is Adam. The user is a man. The user is 29 years old.
Give a positive affirmation or inspirational quote to the user.
"""

def get_affirmation():
    response = requests.post(
        OLLAMA_URL,
        headers={"Content-Type": "application/json"},
        data=json.dumps({
            "model": "qwen3:4b",
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": "Hello, from the terminal"}
            ],
        }),
    )
    return response.json()["choices"][0]["message"]["content"]


print(get_affirmation())

