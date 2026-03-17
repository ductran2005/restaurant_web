package market.restaurant_web.service;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.UUID;

public class SupabaseStorageService {

    // ──────────────────────────────────────────────
    // ⚠ CHANGE THESE TO YOUR OWN VALUES
    // ──────────────────────────────────────────────
    private static final String SUPABASE_URL = "https://bstcdtpgtbvpsitnogzd.supabase.co";
    private static final String SUPABASE_KEY = "sb_publishable_0yLprW5CulX9guvlDVP7SQ_UZXvKGyw";
    private static final String BUCKET = "product-images";

    private SupabaseStorageService() {
    }

    /**
     * Uploads an image to Supabase Storage.
     *
     * @param inputStream the file data
     * @param fileName    original file name (e.g. "pho-bo.jpg")
     * @param contentType MIME type (e.g. "image/jpeg")
     * @return the public URL of the uploaded image
     * @throws IOException if upload fails
     */
    public static String uploadImage(InputStream inputStream, String fileName, String contentType)
            throws IOException {

        // Generate unique file name to avoid collisions
        String ext = "";
        int dotIdx = fileName.lastIndexOf('.');
        if (dotIdx > 0) {
            ext = fileName.substring(dotIdx); // ".jpg"
        }
        String uniqueName = UUID.randomUUID().toString() + ext;
        String objectPath = "products/" + uniqueName; // stored under products/ folder

        // Supabase Storage REST endpoint
        String uploadUrl = SUPABASE_URL + "/storage/v1/object/" + BUCKET + "/" + objectPath;

        URL url = URI.create(uploadUrl).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Bearer " + SUPABASE_KEY);
        conn.setRequestProperty("apikey", SUPABASE_KEY);
        conn.setRequestProperty("Content-Type", contentType);
        // x-upsert to overwrite if exists
        conn.setRequestProperty("x-upsert", "true");

        // Write file bytes to request body
        try (OutputStream os = conn.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        if (responseCode != 200 && responseCode != 201) {
            // Read error message
            String errBody = "";
            try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null)
                    sb.append(line);
                errBody = sb.toString();
            } catch (Exception ignored) {
            }
            throw new IOException("Supabase upload failed (" + responseCode + "): " + errBody);
        }

        conn.disconnect();

        // Return the public URL (bucket is PUBLIC)
        return SUPABASE_URL + "/storage/v1/object/public/" + BUCKET + "/" + objectPath;
    }

    /**
     * Deletes an image from Supabase Storage.
     *
     * @param publicUrl the full public URL of the image
     * @return true if deleted successfully
     */
    public static boolean deleteImage(String publicUrl) {
        if (publicUrl == null || publicUrl.isEmpty())
            return false;

        try {
            // Extract the object path from the public URL
            String marker = "/storage/v1/object/public/" + BUCKET + "/";
            int idx = publicUrl.indexOf(marker);
            if (idx < 0)
                return false;
            String objectPath = publicUrl.substring(idx + marker.length());

            String deleteUrl = SUPABASE_URL + "/storage/v1/object/" + BUCKET + "/" + objectPath;

            URL url = URI.create(deleteUrl).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("DELETE");
            conn.setRequestProperty("Authorization", "Bearer " + SUPABASE_KEY);
            conn.setRequestProperty("apikey", SUPABASE_KEY);

            int code = conn.getResponseCode();
            conn.disconnect();
            return code == 200 || code == 204;
        } catch (Exception e) {
            System.err.println("Failed to delete image: " + e.getMessage());
            return false;
        }
    }
}
