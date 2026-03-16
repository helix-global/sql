using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SearchedCaseExpression))]
    internal sealed class SqlFragmentSearchedCaseExpression : SqlFragmentCaseExpression<SearchedCaseExpression>
        {
        #region ctor{IServiceProvider,SearchedCaseExpression}
        public SqlFragmentSearchedCaseExpression(IServiceProvider context,SearchedCaseExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }