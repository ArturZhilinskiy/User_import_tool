public class UsersPerPage {

	public class Ad {
		public String company;
		public String url;
		public String text;
	}

	public class Data {
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
	public List<Data> data;
	public Ad ad;

	
	public static UsersPerPage parse(String json) {
		return (UsersPerPage) System.JSON.deserialize(json, UsersPerPage.class);
	}
}
