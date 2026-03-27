using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlModelFieldMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String Source { get;set; }
        public Boolean EmptyIfNull { get;set; }

        #region ctor
        public SqlModelFieldMappingAttribute()
            {
            }
        #endregion
        #region ctor{String}
        public SqlModelFieldMappingAttribute(String Source)
            {
            this.Source = Source;
            }
        #endregion
        }
    }
