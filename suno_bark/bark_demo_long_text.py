# install bark (make sure you have torch>=2 for much faster flash-attention)
# !pip install git+https://github.com/suno-ai/bark.git


from bark import SAMPLE_RATE, generate_audio, preload_models
from bark.api import semantic_to_waveform
# from IPython.display import Audio
from scipy.io.wavfile import write as write_wav
import nltk  # we'll use this to split into sentences
import numpy as np

from bark.generation import (
    generate_text_semantic,
    preload_models,
)

preload_models()
nltk.download('punkt')

from scipy.io.wavfile import write as write_wav
import nltk  # we'll use this to split into sentences
import numpy as np

script = """
I have a dream.
""".replace("\n", " ").strip()

# Read text from input.txt
with open("pri/input.txt", "r") as file:
    script = file.read().replace("\n", " ").strip()


sentences = nltk.sent_tokenize(script)


GEN_TEMP = 0.6
SPEAKER = "v2/en_speaker_9"
silence = np.zeros(int(0.25 * SAMPLE_RATE))  # quarter second of silence


pieces = []
for i, sentence in enumerate(sentences):
    print( f"generating {i + 1} of {len(sentences)} items")
    # sentence = "♪ " + sentence + " ♪"
    # sentence = "[gentle and commanding] " + sentence
    semantic_tokens = generate_text_semantic(
        sentence,
        history_prompt=SPEAKER,
        temp=GEN_TEMP,
        min_eos_p=0.05,  # this controls how likely the generation is to end
    )

    audio_array = semantic_to_waveform(semantic_tokens, history_prompt=SPEAKER,)
    pieces += [audio_array, silence.copy()]


audio_array = np.concatenate(pieces)

# audio_array = generate_audio(text_prompt, history_prompt="v2/en_speaker_9")
# save audio to disk

import soundfile as sf
# save audio to disk as mp3 
sf.write("bark_generation.mp3", audio_array, SAMPLE_RATE)

# write_wav("bark_generation.wav", SAMPLE_RATE, audio_array)
# Audio(audio_array, rate=SAMPLE_RATE*1.1)



