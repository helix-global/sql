using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlColumn : ISqlColumn,ISqlQualifiedObject
        {
        public SqlIdentifier Name { get; }
        public SqlObjectIdentifier QualifiedName { get; }
        public Boolean IsComputed { get; }
        public ISqlTypeSpecifier TypeSpecifier { get; }
        public IList<ISqlConstraint> Constraints { get; }

        public SqlColumn(ISqlQualifiedObject owner,ISqlColumn source) {
            TypeSpecifier = source.TypeSpecifier;
            Constraints = source.Constraints;
            Name = source.Name;
            QualifiedName = owner.QualifiedName + source.Name;
            IsComputed = source.IsComputed;
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