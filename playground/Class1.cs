using System;

namespace playground
{
    public class Class1
    {
        private Int32 _id;
        private String _title;

        public Int32 Id {
            get { return this._id; }
            set { this._id = value; }
        }

        public String Title{
            get { return this._title; }
            set { this._title = value;}
        }

        public Class1(){
            // empty constructor code here
            Title = "Some Title";
        }

        public Class1(Int32 id){
            Id = id;
        }
    }
}
