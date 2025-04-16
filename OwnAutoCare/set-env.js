const fs = require('fs');

const environmentFile = `export const environment = {
  apiKey: '${process.env.API_KEY}',
  clientId: '${process.env.CLIENT_ID}',
};
`;

// Generate environment.ts file
fs.writeFile('./src/environments/environment.ts', environmentFile, function (err) {
  if (err) {
    throw console.error(err);
  } else {
    console.log(`Angular environment.ts file generated`);
  }
});
