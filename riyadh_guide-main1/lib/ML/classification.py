#import
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import pandas as pd
import os
import re
import nltk
nltk.download('punkt')
from nltk.stem.isri import ISRIStemmer
from nltk.corpus import stopwords
import string
from nltk.tokenize import word_tokenize
nltk.download('stopwords')                                                                                             





#Connection To dataBase
# Path to the service account key JSON file
cred = credentials.Certificate('C:/Dev/riyadh-guide-database-9528e-firebase-adminsdk-4nmk9-34999ee77d.json')

# Initialize the app with the service account key
firebase_admin.initialize_app(cred)














#Read compined file
df = pd.read_excel('C:/Dev/AllData.xlsx')
# Select only the second and third columns
new_df = df.iloc[:, 1:3]
# Rename the columns
new_df.columns = ['Review', 'Class']# Check for missing values in the 'Review' column
print(new_df['Review'].isnull().sum())
# Check for missing values in the 'Review' column
missing_review_rows = new_df[new_df['Review'].isnull()]

# Print the rows with missing values in the 'Review' column
#print(missing_review_rows)
# Drop rows with missing values in the 'Review' column
new_df = new_df.dropna(subset=['Review'])

# Reset the index after dropping rows
new_df = new_df.reset_index(drop=True) # Assuming 'new_df' is your DataFrame with 'Class' column
class_counts = new_df['Class'].value_counts()

# Print the count of each class
#print("Class Counts:")
#print(class_counts)
# Remove duplicates
new_df.drop_duplicates(inplace=True)

# Function to delete English letters
def delete_english_letters(text):
    return re.sub(r'[a-zA-Z]', '', text)

# Delete English letters from the 'Review' column
new_df['Review'] = new_df['Review'].apply(delete_english_letters)

# Function to remove tashkeel and harakat
def remove_tashkeel_harakat(text):
    tashkeel_harakat_pattern = re.compile(r'[\u064B-\u0652]')
    return tashkeel_harakat_pattern.sub('', text)


#calling methods
# Remove tashkeel and harakat from the 'Review' column
new_df['Review'] = new_df['Review'].apply(remove_tashkeel_harakat)


# Define the emoji removal pattern
emoji_pattern = re.compile("["
        u"\U0001F600-\U0001F64F"  # emoticons
        u"\U0001F300-\U0001F5FF"  # symbols & pictographs
        u"\U0001F680-\U0001F6FF"  # transport & map symbols
        u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
                           "]+", flags=re.UNICODE)

# Set display options to show the full text in the 'Review' column
pd.set_option('display.max_colwidth', None)
pd.set_option('display.max_columns', None)

# Remove numbers from the 'Review' column
new_df['Review'] = new_df['Review'].apply(lambda x: re.sub(r'\d+', '', str(x)))

# Apply emoji removal to the 'Review' column
new_df['Review'] = new_df['Review'].apply(lambda x: emoji_pattern.sub(r'', str(x)))
## removing prefix - suffix

def light_stem(text):
    words = text.split()
    result = list()
    stemmer = ISRIStemmer()
    for word in words:
        word = stemmer.norm(word, num=1)      # remove diacritics which representing Arabic short vowels
        word = stemmer.pre32(word)        # remove length three and length two prefixes in this order
        word = stemmer.suf32(word)        # remove length three and length two suffixes in this order
        word = stemmer.waw(word)          # remove connective ‘و’ if it precedes a word beginning with ‘و’
        word = stemmer.norm(word, num=2)  # normalize initial hamza to bare alif
        #word = stemmer.stem(word)

        result.append(word)
    return ' '.join(result)


new_df['Review'] = new_df['Review'].apply(light_stem)

## remove repeted characters
def remove_repeated_char(text):
    return re.sub(r'(.)\1+', r'\1\1', text)     # keep 2 repeat

new_df['Review'] = new_df['Review'].apply(remove_repeated_char)

#Tokenize the Arabic reviews
new_df['Review'] = new_df['Review'].apply(nltk.word_tokenize)

stop_words = list(set(stopwords.words('arabic')))

arabic_punctuations = '''`÷×؛،<>_()*&^%][ـ،/:"؟.,'{}~¦+|!”…“–ـ'''
english_punctuations = string.punctuation
punctuations_list = arabic_punctuations + english_punctuations

def remove_stop_words_and_punctuations(tokens):
    filtered_tokens = [word for word in tokens if word not in stop_words and word not in string.punctuation]
    filtered_tokens = [re.sub(r'[^a-zA-Z0-9\u0600-\u06FF\s]', '', token) for token in tokens if token.strip()]
    return filtered_tokens

new_df['Review'] = new_df['Review'].apply(remove_stop_words_and_punctuations)





# Logistic regression model
# Import necessary libraries
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import GridSearchCV

# Assuming 'Review' and 'Class' are columns in your DataFrame
texts_train = new_df['Review']
labels_train = new_df['Class']

# Convert labels to numerical representation
label_encoder = LabelEncoder()
encoded_labels_train = label_encoder.fit_transform(labels_train)

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(texts_train, encoded_labels_train, test_size=0.2, random_state=42)

# Convert the tokenized words back to strings
X_train_str = [' '.join(tokens) for tokens in X_train]
X_test_str = [' '.join(tokens) for tokens in X_test]

# Convert the text data into Bag-of-Words representation
vectorizer = CountVectorizer()
X_train_bow = vectorizer.fit_transform(X_train_str)
X_test_bow = vectorizer.transform(X_test_str)



# Create logistic regression model
logistic_model = LogisticRegression()

# Define hyperparameter grid
param_grid = {'C': [0.001, 0.01, 0.1, 1, 10, 100], 'max_iter': [100, 200, 300]}

# Create GridSearchCV
grid_search = GridSearchCV(logistic_model, param_grid, cv=5, scoring='accuracy', n_jobs=-1)

# Convert the text data into Bag-of-Words representation
vectorizer = CountVectorizer()
X_train_bow = vectorizer.fit_transform(X_train_str)
X_test_bow = vectorizer.transform(X_test_str)

# Fit the grid search to the data
grid_search.fit(X_train_bow, y_train)

# Print the best hyperparameters found by grid search
print("Best Hyperparameters:", grid_search.best_params_)

# Use the best model found by grid search for predictions
best_model = grid_search.best_estimator_
y_pred = best_model.predict(X_test_bow)

# Calculate and print the test accuracy
test_accuracy = accuracy_score(y_test, y_pred)
print(f'Test Accuracy: {test_accuracy * 100:.2f}%')

# Evaluate the best model on the test set
precision = precision_score(y_test, y_pred, average='weighted')
recall = recall_score(y_test, y_pred, average='weighted')
f1 = f1_score(y_test, y_pred, average='weighted')
conf_matrix = confusion_matrix(y_test, y_pred)

# Print the evaluation metrics for the test set
print(f'Precision: {precision}')
print(f'Recall: {recall}')
print(f'F1-Score: {f1}')
print('Confusion Matrix:')
print(conf_matrix)
import numpy as np







#Prediction For new Place Data
# Load new data from a file into a DataFrame
  # Change the path accordingly
new_data = df = pd.read_excel('C:/Dev/wadi1.xlsx')
# Assume 'new_data' is a DataFrame containing the new reviews in the 'Review' column
# Drop rows with null or missing values in the 'Review' column
new_data.dropna(subset=['Review'], inplace=True)

# Preprocess the new data
new_data['Review'] = new_data['Review'].apply(delete_english_letters)
new_data['Review'] = new_data['Review'].apply(remove_tashkeel_harakat)
new_data['Review'] = new_data['Review'].apply(lambda x: re.sub(r'\d+', '', str(x)))
new_data['Review'] = new_data['Review'].apply(lambda x: emoji_pattern.sub(r'', str(x)))
new_data['Review'] = new_data['Review'].apply(light_stem)
new_data['Review'] = new_data['Review'].apply(remove_repeated_char)
new_data['Review'] = new_data['Review'].apply(nltk.word_tokenize)
new_data['Review'] = new_data['Review'].apply(remove_stop_words_and_punctuations)
# Remove empty lists from the 'Review' column
new_data['Review'] = new_data['Review'].apply(lambda x: [token for token in x if token.strip()])

# Filter out rows where 'Review' is an empty list
new_data = new_data[new_data['Review'].apply(len) > 0]

# Convert the tokenized words back to strings
new_data_str = [' '.join(tokens) for tokens in new_data['Review']]

# Convert the text data into Bag-of-Words representation using the same vectorizer
new_data_bow = vectorizer.transform(new_data_str)

# Make predictions on the new data
new_predictions = best_model.predict(new_data_bow)

# Convert numerical labels back to original class names
new_predictions_classes = label_encoder.inverse_transform(new_predictions)
# Print each review with its corresponding predicted label
for i, (review, prediction) in enumerate(zip(new_data_str, new_predictions_classes)):
    print(f"Review {i+1}: {review} - Predicted Label: {prediction}")
# Add predicted labels as a new column in the new_data DataFrame
new_data['Predicted Label'] = new_predictions_classes



# Count the occurrences of each label in the predictions
label_counts = np.bincount(new_predictions, minlength=3)

# Print the count of each label
for label, count in enumerate(label_counts):
    print(f"Label {label-1}: Count = {count}")

# Find the label with the highest count
final_classification = max(range(len(label_counts)), key=lambda x: label_counts[x]) - 1

# Print the final classification based on the label with the highest count
print("Final Classification:", final_classification)



# Print each review with its corresponding predicted label
for i, (review, prediction) in enumerate(zip(new_data_str, new_predictions_classes)):
    print(f"Review {i+1}: {review} - Predicted Label: {prediction}")


# Count the occurrences of each label in the predictions
label_counts = np.bincount(new_predictions, minlength=3)

# Print the count of each label
for label, count in enumerate(label_counts):
    print(f"Label {label-1}: Count = {count}")

# Find the label with the highest count
final_classification = max(range(len(label_counts)), key=lambda x: label_counts[x]) - 1


# Calculate the percentage of label 1
label_1_count = label_counts[2]
total_count = np.sum(label_counts)
label_1_percentage = (label_1_count / total_count) * 100

# Convert the percentage to an integer
label_1_percentage = int(label_1_percentage)

# Print the percentage of label 1
print(f"Percentage of how much people like the place: {label_1_percentage}%")


# Print the final classification based on the label with the highest count
print("Final Classification:", final_classification)


db = firestore.client()

# Access the "place" collection and the document with ID "-"
collection_ref = db.collection('place')
document_ref = collection_ref.document('p29')

# Convert the classification value to a string
classification_str = str(final_classification)

# Update specific fields in the document
document_ref.update({
   'classification': classification_str,
   'percentage': label_1_percentage
})