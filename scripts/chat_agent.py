import sys
import ollama

def validate_terraform(tf_content):
    prompt = f"""
You are a Terraform expert. Analyze the following Terraform code.

If issues exist, your final verdict **must include the word FAIL**.
If no issues exist, final verdict must include **PASS**.

Provide:

1. Syntax issues  
2. Security findings  
3. Hardcoded values  
4. Missing tags  
5. Naming issues  
6. Optimization suggestions  
7. Final PASS/FAIL verdict  

Terraform Code:
{tf_content}
Return output in a clean, bullet-point format.
"""
    

    response = ollama.chat(
        model="llama3.2",
        messages=[{"role": "user", "content": prompt}]
    )

    return response["message"]["content"]


def main():
    if len(sys.argv) < 2:
        print("Usage: python tf_validator.py <terraform_file.tf>")
        sys.exit(1)

    tf_file = sys.argv[1]

    with open(tf_file, "r") as f:
        tf_content = f.read()

    print("🔍 Validating Terraform code with Llama3.2...\n")
    result = validate_terraform(tf_content)

    print("===== Terraform Validation Report =====")
    print(result)
    print("=======================================")


if __name__ == "__main__":
    main()