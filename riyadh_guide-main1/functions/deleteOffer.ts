import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Cloud Function to delete expired offers
exports.deleteExpiredOffers = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const offersRef = admin.firestore().collection('offer');
    
    const querySnapshot = await offersRef.where('endDate', '<', now).get();
    
    const batch = admin.firestore().batch();
    querySnapshot.forEach((doc) => {
        batch.delete(doc.ref);
        console.log('Document deleted:', doc.id);
    });
    
    return batch.commit();
});

