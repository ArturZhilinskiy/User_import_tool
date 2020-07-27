public class UsersPerPage {

	public class AdditionInfo {
		public String company;
		public String url;
		public String text;
	}

	public class UitUser {
		public Integer id;
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
	public AdditionInfo addition_info;

	
	public static UsersPerPage parse(String jsonString) {
        jsonString = jsonString.replace('"ad":', '"addition_info":');
        jsonString = jsonString.replace('"data":', '"uit_users":');
		return (UsersPerPage) System.JSON.deserialize(jsonString, UsersPerPage.class);
	}
}
