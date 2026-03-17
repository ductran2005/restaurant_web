-- ============================================
-- Supabase Storage RLS Policies cho bucket "product-images"
-- Chạy trong SQL Editor trên Supabase Dashboard
-- ============================================

-- 1. Cho phép ai cũng có thể UPLOAD (INSERT) file
CREATE POLICY "Allow public upload"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'product-images');

-- 2. Cho phép ai cũng có thể XEM (SELECT) file
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'product-images');

-- 3. Cho phép ai cũng có thể CẬP NHẬT (UPDATE/upsert) file
CREATE POLICY "Allow public update"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'product-images');

-- 4. Cho phép ai cũng có thể XÓA (DELETE) file
CREATE POLICY "Allow public delete"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'product-images');
