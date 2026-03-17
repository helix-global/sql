using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlFilterClause))]
    internal sealed class SqlScriptFilterClause : SqlScriptCodeObject<SqlFilterClause>
        {
        [UsedImplicitly][Field] public ISqlScriptFilterExpression FilterExpression { get; }

        #region ctor{IServiceProvider,SqlFilterClause}
        public SqlScriptFilterClause(IServiceProvider context,SqlFilterClause source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Script;
            }
        #endregion
        }
    }