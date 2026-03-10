using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptColumnDefinition<T> : SqlScriptCodeObject<T>,ISqlScriptColumnDefinition
        where T: SqlColumnDefinition
        {
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptConstraint> Constraints { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptColumnDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlColumnDefinition))]
    internal class SqlScriptColumnDefinition : SqlScriptColumnDefinition<SqlColumnDefinition>
        {
        #region ctor{IServiceProvider,SqlColumnDefinition}
        public SqlScriptColumnDefinition(IServiceProvider context,SqlColumnDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }