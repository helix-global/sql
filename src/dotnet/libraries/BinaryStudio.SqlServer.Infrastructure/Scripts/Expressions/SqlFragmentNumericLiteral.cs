using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(NumericLiteral))]
    internal sealed class SqlFragmentNumericLiteral : SqlFragmentLiteral<NumericLiteral>
        {
        #region ctor{IServiceProvider,NumericLiteral}
        public SqlFragmentNumericLiteral(IServiceProvider context,NumericLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }