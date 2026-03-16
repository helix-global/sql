using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ScalarExpressionSnippet))]
    internal sealed class SqlFragmentScalarExpressionSnippet : SqlFragmentScalarExpression<ScalarExpressionSnippet>
        {
        #region ctor{IServiceProvider,ScalarExpressionSnippet}
        public SqlFragmentScalarExpressionSnippet(IServiceProvider context,ScalarExpressionSnippet source)
            : base(context,source)
            {
            }
        #endregion
        }
    }