# Functional Requirements of SisuHyy, a Finnish learning APP

## 1. News Reading and Content Fetching

* The system shall fetch and display news articles from **Yle uutiset** and **Yle selkouutiset**.
* The system shall extract the following from each article:

  * Title and publication date
  * Subheadings and paragraphs
* The system shall store fetched news articles locally for offline reading.
* The user shall be able to tap or long-press any word in the article to get its meaning.

## 2. Word Definition and Grammar Analysis

* The system shall identify and display the **lemma (base form)** of any selected word.
* The system shall show the **word class (e.g., noun, verb, adjective)**.
* The system shall display the **inflected form details** (case, tense, number, etc.) if applicable.
* The system shall show **compound word analysis**, displaying meanings of each part.
* The system shall fetch word definitions and example sentences from external sources such as **suomisanakirja.fi**.
* The user shall be able to view a simple Finnish explanation (instead of translation).

## 3. Vocabulary Management (Word Bank)

* The user shall be able to **add words** to their personal vocabulary list (word bank).
* Each saved word shall include:

  * Lemma (base form)
  * Definition
  * Example sentence(s)
  * Date added
  * AI-generated image (optional)
* The user shall be able to **search, edit, or delete** words from the word bank.
* The app shall store the vocabulary data locally (for the single-user offline version).

## 4. Flashcard Generation and Review

* The system shall automatically generate **flashcards** from saved words.
* Each flashcard shall include:

  * **Front side:** AI-generated image and a short Finnish explanation
  * **Back side:** Word form, definition, and example sentence
* The user shall be able to review flashcards in **spaced repetition mode** or **manual review mode**.
* The user shall be able to mark a word as “learned.”

## 5. AI Image Generation

* The system shall use an **AI image generation model** (e.g., DALL·E or Stable Diffusion) to create a visual representation of a word.
* The generated image shall be displayed on the word’s detail page and flashcard.
* The user shall be able to regenerate or replace an image manually.

## 6. User Interface and Interaction

* The system shall display news articles in a **scrollable and readable layout**.
* When a user taps a word, a **popup window** shall display its definition and related details.
* The system shall provide navigation tabs for:

  * Home / News Feed
  * Word Bank
  * Flashcards
  * Settings

