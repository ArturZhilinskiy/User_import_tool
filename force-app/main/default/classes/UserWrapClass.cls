public with sharing class UserWrapClass {

	public class UitUser {
		public String id;
		public String email;
		public String first_name;
		public String last_name;
        public String avatar;
	}

	public Integer page;
	public Integer per_page;
	public Integer total;
	public Integer total_pages;
	public List<UitUser> uit_users;

	public static UserWrapClass parse(String jsonString) {
        jsonString = jsonString.replace('"data":', '"uit_users":');
		return (UserWrapClass) System.JSON.deserialize(jsonString, UserWrapClass.class);
    }
}
