// Point d’entrée des Cloud Functions JeuTaime
import * as callables from './callables';
import * as triggers from './triggers';
import * as cron from './cron';
import * as webhooks from './webhooks';

// Export des fonctions
export {
  ...callables,
  ...triggers,
  ...cron,
  ...webhooks
};
