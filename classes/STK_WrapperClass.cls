/**
 * Created by mbesmonte on 5/10/2018.
 */

public class STK_WrapperClass {

        public String id;
        public String document_id;
        public String remote_id;
        public String file_name;
        public String media_link;
        public String media_link_original;
        public String media_link_data;
        public Integer page_count;
        public String uploaded_at;
        public String processed_at;
        public Barcodedata1 ccadata;
        public Barcodedata1[] ccadetails;

        public STK_WrapperClass(String id, String document_id, String remote_id, String file_name, String media_link,
                String media_link_original, String media_link_data, Integer page_count, String uploaded_at,
                String processed_at){
            this.id = id;
            this.document_id = document_id;
            this.remote_id = remote_id;
            this.file_name = file_name;
            this.media_link = media_link;
            this.media_link_data = media_link_data;
            this.media_link_original = media_link_original;
            this.page_count = page_count;
            this.uploaded_at = uploaded_at;
            this.processed_at = processed_at;
            this.ccadata = new Barcodedata1();
            this.ccadetails = new List<Barcodedata1>();

        }

    public class Barcodedata1 {
        public String key_0;
        public String key_1;
    }
}