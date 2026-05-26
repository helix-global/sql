using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SourceDeclaration))]
    internal sealed class SqlFragmentSourceDeclaration : SqlFragmentScalarExpression<SourceDeclaration>
        {
        #region ctor{IServiceProvider,SourceDeclaration}
        public SqlFragmentSourceDeclaration(IServiceProvider context,SourceDeclaration source)
            : base(context,source)
            {
            }
        #endregion
        }
    }