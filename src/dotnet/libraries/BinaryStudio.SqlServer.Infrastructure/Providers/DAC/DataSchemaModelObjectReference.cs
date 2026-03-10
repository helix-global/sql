using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelObjectReference : SqlObjectReference
        {
        public Int32? Disambiguator { get;internal set; }

        public DataSchemaModelObjectReference(SqlObjectIdentifier Reference,Boolean IsBultIn)
            : base(Reference,IsBultIn)
            {
            }

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString() {
            return (Reference != (SqlObjectIdentifier)null)
                ? Reference.ToString()
                : "{none}";
            }
        #endregion
        }
    }