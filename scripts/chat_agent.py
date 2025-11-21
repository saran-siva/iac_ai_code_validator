import ollama

def main():
    print("Running Local LLM via Ollama after PR merge...")

    response = ollama.chat(
        model="llama3.2",
        messages=[
            {"role": "system", "content": "You are an automation bot."},
            {"role": "user", "content": "A PR was merged. Provide a summary and next steps."}
        ]
    )

    print("\nLLM Response:")
    print(response["message"]["content"])

if __name__ == "__main__":
    main()
