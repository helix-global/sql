using System;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlView
        {
        public SqlObjectIdentifier QualifiedName { get; }

        public SqlView(SqlScriptCreateViewStatement source)
            {
            QualifiedName = source.Name;
            }

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return QualifiedName.ToString();
            }
        #endregion
        }
    }