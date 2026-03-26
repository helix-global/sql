using System;
using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlScriptObjectConverter))]
    internal abstract class SqlScriptObject : SqlObject
        {
        #region ctor{IServiceProvider,SqlCodeObject}
        protected SqlScriptObject(IServiceProvider context,Object source)
            : base(context,source)
            {
            }
        #endregion
        }
    }