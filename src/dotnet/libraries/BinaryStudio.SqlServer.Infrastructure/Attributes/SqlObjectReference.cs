using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlObjectReference
        {
        public SqlObjectIdentifier Reference { get; }
        public Boolean IsBultIn { get; }

        public SqlObjectReference(SqlObjectIdentifier Reference,Boolean IsBultIn) {
            this.Reference = Reference;
            this.IsBultIn = IsBultIn;
            }

        override public String ToString() {
            return Reference.ToString();
            }
        }
    }
