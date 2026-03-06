using System;
using System.Collections.Generic;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlBatch))]
    internal sealed class SqlScriptBatch : SqlScriptCodeObject<SqlBatch>
        {
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptStatement> Statements { get; }

        #region ctor{IServiceProvider,SqlBatch}
        public SqlScriptBatch(IServiceProvider context,SqlBatch source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }