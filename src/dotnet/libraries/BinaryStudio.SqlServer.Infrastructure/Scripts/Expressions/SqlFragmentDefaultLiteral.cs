using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(DefaultLiteral))]
    internal sealed class SqlFragmentDefaultLiteral : SqlFragmentLiteral<DefaultLiteral>
        {
        #region ctor{IServiceProvider,DefaultLiteral}
        public SqlFragmentDefaultLiteral(IServiceProvider context,DefaultLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }