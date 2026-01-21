import re
import sys
from bs4 import BeautifulSoup

def count_syllables(word):
    word = word.lower()
    if len(word) <= 3:
        return 1
    word = re.sub(r'(?:[^laeiouy]|ed|[^laeiouy]es|window)$', '', word)
    word = re.sub(r'^y', '', word)
    vowels = re.findall(r'[aeiouy]{1,2}', word)
    return max(1, len(vowels))

def is_complex(word):
    # Avoid counting proper nouns or simple compound words as complex if possible
    # but for a basic Fog Index, 3+ syllables is the standard.
    if '-' in word:
        return False
    return count_syllables(word) >= 3

def calculate_gunning_fog(text):
    sentences = re.split(r'[.!?]+', text)
    sentences = [s for s in sentences if len(s.strip()) > 0]
    
    words = re.findall(r'\w+', text)
    word_count = len(words)
    sentence_count = len(sentences)
    
    if word_count == 0 or sentence_count == 0:
        return 0
    
    complex_words = [w for w in words if is_complex(w)]
    complex_word_count = len(complex_words)
    
    average_sentence_length = word_count / sentence_count
    percentage_complex_words = (complex_word_count / word_count) * 100
    
    fog_index = 0.4 * (average_sentence_length + percentage_complex_words)
    return fog_index

def main():
    if len(sys.argv) < 2:
        print("Usage: python gunning_fog.py <file_path>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if file_path.endswith('.html'):
        soup = BeautifulSoup(content, 'html.parser')
        # Remove script and style elements
        for script in soup(["script", "style"]):
            script.decompose()
        text = soup.get_text(separator=' ')
    else:
        text = content
    
    # Clean up whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    
    index = calculate_gunning_fog(text)
    print(f"Gunning Fog Index: {index:.2f}")

if __name__ == "__main__":
    main()
