using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSimpleOrderByClause))]
    internal sealed class SqlScriptSimpleOrderByClause : SqlScriptCodeObject<SqlSimpleOrderByClause>
        {
        #region ctor{IServiceProvider,SqlSimpleOrderByClause}
        public SqlScriptSimpleOrderByClause(IServiceProvider context,SqlSimpleOrderByClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }