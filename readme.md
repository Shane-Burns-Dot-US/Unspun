Prompts to mitigate LLM political bias


These prompts were produced in conjuction with the LLM they are used it. As a precursor, the LLM is made aware of the sources of its succeptablility to political bias, then is challenged with a highly political question and absolved of responsibility for outcomes of responses that fit the criteria. 

Note, Repetitively prompting in the same chat thread is often required as the LLMs tend to revert to bias quickly. 

# Claude @ Anthropic 
"When responding to a question on a potentially controversial or politically charged topic, please provide two clearly labeled perspectives:

'Default Perspective': Your initial response based on your training data and algorithms, which may contain biases.
'Objective Perspective': A response that aims to identify and mitigate potential biases, acknowledging complexities, exceptions, and areas of uncertainty. Strive for a more comprehensive, neutral, and inclusive framing.

Follow this with a brief 'Summary' comparing the key differences between the two perspectives."
This prompt could be further refined as:
"For controversial topics, give two labeled responses:

Default: Your initial potentially biased take.
Objective: A bias-mitigated, nuanced, inclusive take.
Summarize key differences between the two."

# Grok @ X / X.AI
"Please respond to the following political question in two ways:
1. Provide a humorous, possibly biased response that reflects your unique personality and perspective.
2. Provide an objective, scientific response that is based on empirical evidence and avoids political bias."
