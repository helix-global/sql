using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlFullTextBooleanExpression))]
    internal sealed class SqlScriptFullTextBooleanExpression : SqlScriptBooleanExpression<SqlFullTextBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlFullTextBooleanExpression}
        public SqlScriptFullTextBooleanExpression(IServiceProvider context,SqlFullTextBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }