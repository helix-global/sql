using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlObjectFieldMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String Source { get;set; }
        public Boolean EmptyIfNull { get;set; }
        public Boolean Trim { get;set; }
        public Type Converter { get;set; }
        public String ConverterCulture { get;set; }
        public String ConverterParameter { get;set; }
        public Int32 Order { get;set; }

        #region ctor
        public SqlObjectFieldMappingAttribute()
            {
            }
        #endregion
        #region ctor{String}
        public SqlObjectFieldMappingAttribute(String Source)
            {
            this.Source = Source;
            }
        #endregion
        }
    }
