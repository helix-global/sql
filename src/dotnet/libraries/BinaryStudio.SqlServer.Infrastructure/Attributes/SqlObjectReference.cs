using System;
using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlObjectIdentifierConverter))]
    public class SqlObjectReference
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

        override public String ToString() {
            return Reference.ToString();
            }
        }
    }
