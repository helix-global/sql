using System;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlColumn : ISqlColumn,ISqlQualifiedObject
        {
        public SqlIdentifier Name { get; }
        public SqlObjectIdentifier QualifiedName { get; }

        public SqlColumn(ISqlQualifiedObject owner,ISqlScriptColumnDefinition source) {
            Name = source.Name;
            QualifiedName = owner.QualifiedName + source.Name;
            }

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return QualifiedName.ObjectName.ToString();
            }
        #endregion

        }
    }