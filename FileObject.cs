public class FileObject {
    private string name;
    public string Name
    {
        get { return name; }
        set { name = value; }
    }

    private long length;
    public long Length
    {
        get { return length; }
        set { length = value; }
    }

    private string parentFolder;
    public string ParentFolder
    {
        get { return parentFolder; }
        set { parentFolder = value; }
    }

    private string createDate;
    public string CreateDate
    {
        get { return createDate; }
        set { createDate = value; }
    }


}