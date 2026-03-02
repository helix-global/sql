using System;
using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlObjectIdentifierConverter))]
    public class SqlObjectReference : ISqlObjectReference
        {
        public static readonly SqlObjectReference Missing = new SqlObjectReference();
        public SqlObjectIdentifier Reference { get; }
        public Boolean IsBultIn { get; }

        #region ctor{SqlObjectIdentifier,Boolean}
        public SqlObjectReference(SqlObjectIdentifier Reference,Boolean IsBultIn) {
            this.Reference = Reference;
            this.IsBultIn = IsBultIn;
            }
        #endregion
        #region ctor
        private SqlObjectReference() {
            this.Reference = null;
            this.IsBultIn = false;
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString() {
            return Reference.ToString();
            }
        #endregion
        }
    }
