import os
from openai import OpenAI

client = OpenAI(api_key=os.getenv("sk-0bNhRn0thfZzxX4bCZQB8Q"))

def main():
    print("Running OpenAI Script after PR Merge...")

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a pipeline automation AI."},
            {"role": "user", "content": "A PR was merged. Provide a summary action and detailed info about the PR."}
        ]
    )

    print("OpenAI Response:")
    print(response.choices[0].message["content"])

if __name__ == "__main__":
    main()
