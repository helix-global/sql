using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlGroupByClause))]
    internal sealed class SqlScriptGroupByClause : SqlScriptCodeObject<SqlGroupByClause>
        {
        #region ctor{IServiceProvider,SqlGroupByClause}
        public SqlScriptGroupByClause(IServiceProvider context,SqlGroupByClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }