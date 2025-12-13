from langchain_core.tools import tool
import requests
import os

def github_headers(url: str):
    if "github.com" in url:
        token = os.getenv("GITHUB_TOKEN")
        if token:
            return {
                "Authorization": f"Bearer {token}",
                "Accept": "application/vnd.github+json"
            }
    return {}


@tool
def download_file(url: str, filename: str) -> str:
    """
    Download a file from a URL and save it with the given filename
    in the current working directory.

    Args:
        url (str): Direct URL to the file.
        filename (str): The filename to save the downloaded content as.

    Returns:
        str: Full path to the saved file.
    """
    try:
        headers = github_headers(url)
        response = requests.get(url, headers=headers, stream=True)
        response.raise_for_status()
        directory_name = "LLMFiles"
        os.makedirs(directory_name, exist_ok=True)
        path = os.path.join(directory_name, filename)
        with open(path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

        return filename
    except Exception as e:
        return f"Error downloading file: {str(e)}"
