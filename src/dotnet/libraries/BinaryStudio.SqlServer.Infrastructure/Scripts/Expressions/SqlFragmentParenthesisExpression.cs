using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ParenthesisExpression))]
    internal sealed class SqlFragmentParenthesisExpression : SqlFragmentPrimaryExpression<ParenthesisExpression>
        {
        #region ctor{IServiceProvider,ParenthesisExpression}
        public SqlFragmentParenthesisExpression(IServiceProvider context,ParenthesisExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }