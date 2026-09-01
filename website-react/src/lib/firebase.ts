import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'

// Same project/config the Flutter app's web build uses (lib/firebase_options.dart
// → DefaultFirebaseOptions.web) — Firebase web API keys are not secrets, they're
// safe to ship client-side; access is governed by Firestore security rules, not
// by hiding this value.
const firebaseConfig = {
  apiKey: 'AIzaSyCV74-c6R-QMmTj-NRBSpOg7pI2wsCW510',
  appId: '1:132008349319:web:66b3cf4586b601e2857222',
  messagingSenderId: '132008349319',
  projectId: 'collabsy-mobile-applicaation',
  authDomain: 'collabsy-mobile-applicaation.firebaseapp.com',
  storageBucket: 'collabsy-mobile-applicaation.firebasestorage.app',
  measurementId: 'G-CVL3VFNMPM',
}

const app = initializeApp(firebaseConfig)
export const db = getFirestore(app)
