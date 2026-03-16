using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlUnpivotClause))]
    internal sealed class SqlScriptUnpivotClause : SqlScriptCodeObject<SqlUnpivotClause>
        {
        #region ctor{IServiceProvider,SqlUnpivotClause}
        public SqlScriptUnpivotClause(IServiceProvider context,SqlUnpivotClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }