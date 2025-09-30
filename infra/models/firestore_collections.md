# Modèles de données Firestore — JeuTaime

## users/{uid}
- uid: string
- pseudo: string
- email: string
- photoUrl: string
- bio: string
- gender: string
- birthdate: timestamp
- certified: bool
- coins: int
- premium: bool
- badges: array<string>
- createdAt: timestamp
- lastActive: timestamp
- settings: map<string, any>

## groups/{groupId}
- groupId: string
- name: string
- members: array<string>
- barId: string
- createdAt: timestamp
- expiresAt: timestamp
- isActive: bool

## bars/{barId}
- barId: string
- name: string
- location: geopoint
- description: string
- photoUrl: string
- isActive: bool
- createdAt: timestamp

## letterThreads/{threadId}
- threadId: string
- participants: array<string> (2 uids)
- createdAt: timestamp
- lastMessageAt: timestamp

## letterMessages/{messageId}
- messageId: string
- threadId: string
- authorUid: string
- content: string
- sentAt: timestamp
- isRead: bool

## purchases/{purchaseId}
- purchaseId: string
- uid: string
- type: string (coins, premium, badge)
- amount: int
- status: string (pending, completed, failed)
- createdAt: timestamp
- stripeSessionId: string

## reports/{reportId}
- reportId: string
- uid: string
- type: string (user, bar, letter)
- targetId: string
- reason: string
- createdAt: timestamp
- status: string (open, closed, rejected)
- adminComment: string

## memories/{memoryId}
- memoryId: string
- uid: string
- barId: string
- content: string
- photoUrl: string
- createdAt: timestamp

## notifications/{notificationId}
- notificationId: string
- uid: string
- type: string
- data: map<string, any>
- read: bool
- createdAt: timestamp

## referrals/{referralId}
- referralId: string
- referrerUid: string
- referredUid: string
- code: string
- createdAt: timestamp
- bonusGiven: bool
