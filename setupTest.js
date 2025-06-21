const { authenticate } = require('@google-cloud/local-auth');
const path = require('path');

// Log para confirmar la ejecución de setupTests.js
console.log(
  '🟢 [setupTests.js] Setup de tests ejecutado (entorno:',
  process.env.NODE_ENV || 'desconocido',
  ')'
);

async function setupGoogleToken() {
  try {
    const auth = await authenticate({
      keyfilePath: path.join(process.cwd(), 'credentials.json'),
      scopes: ['https://www.googleapis.com/auth/drive.file'],
      useLocalAuthCache: true,
      prompt: 'none',
    });

    if (auth.credentials.access_token) {
      process.env.TEST_ACCESS_TOKEN = auth.credentials.access_token;
      process.env.GOOGLE_CLIENT_ID = auth.credentials.client_id;
      process.env.GOOGLE_CLIENT_SECRET = auth.credentials.client_secret;
      console.log('🟢 Token de Google Drive obtenido y configurado');
    } else {
      console.error('❌ No se pudo obtener el token de acceso');
      throw new Error(
        'No se pudo obtener el token de acceso. Asegúrate de que el archivo credentials.json es válido y que el token está cacheado.'
      );
    }
  } catch (error) {
    console.error('❌ Error obteniendo el token de Google Drive:', error.message);
    throw new Error(
      'Error obteniendo el token de Google Drive. Si se abre el navegador, aborta el proceso y verifica que el archivo credentials.json es correcto y que el token está cacheado.'
    );
  }
}

// Ejecutar la configuración y esperar a que termine
module.exports = async () => {
  await setupGoogleToken();
};
